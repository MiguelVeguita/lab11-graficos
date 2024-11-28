Shader "Custom/ParallaxHeightMapShader"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}    // Textura principal
        _HeightMap("Height Map", 2D) = "black" {}    // Mapa de altura
        _HeightScale("Height Scale", Range(0, 0.1)) = 0.05 // Factor de escala de altura
        _Color("Tint Color", Color) = (1, 1, 1, 1)   // Color base
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 300

            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
                #include "Lighting.cginc"
                struct appdata
                {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float2 uv : TEXCOORD0; // Coordenadas UV para la textura
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float2 uv : TEXCOORD0;
                    float3 viewDir : TEXCOORD1;
                };

                sampler2D _MainTex;
                sampler2D _HeightMap;
                float4 _Color;
                float _HeightScale;

                v2f vert(appdata v)
                {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);

                    // Pasar las coordenadas UV al fragment shader
                    o.uv = v.uv;

                    // Calcula la dirección de vista (view direction) en el espacio de objeto
                    float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                    o.viewDir = normalize(_WorldSpaceCameraPos - worldPos);

                    return o;
                }

                float4 frag(v2f i) : SV_Target
                {
                    // Mapa de altura
                    float height = tex2D(_HeightMap, i.uv).r; // Solo se usa el canal rojo del height map
                    float2 offset = (i.viewDir.xy * (height * _HeightScale)) / i.viewDir.z;

                    // Ajusta las coordenadas UV con el desplazamiento calculado
                    float2 parallaxUV = i.uv + offset;

                    // Aplica el color de la textura con el tinte
                    float4 texColor = tex2D(_MainTex, parallaxUV) * _Color;

                    return texColor;
                }
                ENDCG
            }
        }
            FallBack "Diffuse"
}
