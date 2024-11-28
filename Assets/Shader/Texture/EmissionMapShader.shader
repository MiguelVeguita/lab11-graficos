Shader "Custom/EmissionMapShader"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}        // Textura principal
        _EmissionMap("Emission Map", 2D) = "black" {}    // Mapa de emisión
        _EmissionColor("Emission Color", Color) = (1, 1, 1, 1) // Color de emisión
        _EmissionStrength("Emission Strength", Range(0, 10)) = 1.0 // Intensidad de la emisión
        _Color("Tint Color", Color) = (1, 1, 1, 1)       // Color base
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 200

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
                };

                sampler2D _MainTex;
                sampler2D _EmissionMap;
                float4 _EmissionColor;
                float _EmissionStrength;
                float4 _Color;

                v2f vert(appdata v)
                {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv; // Pasar las coordenadas UV al fragment shader
                    return o;
                }

                float4 frag(v2f i) : SV_Target
                {
                    // Obtener el color base de la textura
                    float4 texColor = tex2D(_MainTex, i.uv) * _Color;

                    // Obtener el valor del mapa de emisión y aplicar el color de emisión
                    float3 emission = tex2D(_EmissionMap, i.uv).rgb * _EmissionColor.rgb * _EmissionStrength;

                    // Combinar el color de la textura con la emisión
                    float3 finalColor = texColor.rgb + emission;

                    return float4(finalColor, texColor.a);
                }
                ENDCG
            }
        }
            FallBack "Diffuse"
}
