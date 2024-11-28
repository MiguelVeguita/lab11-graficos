Shader "Custom/OcclusionMapShader"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}       // Textura principal
        _OcclusionMap("Occlusion Map", 2D) = "white" {} // Mapa de oclusión
        _OcclusionStrength("Occlusion Strength", Range(0, 10)) = 1.0 // Intensidad de oclusión
        _Color("Tint Color", Color) = (1, 1, 1, 1)      // Color base
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
                sampler2D _OcclusionMap;
                float _OcclusionStrength;
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
                    // Obtiene el color base de la textura y aplica el tinte
                    float4 texColor = tex2D(_MainTex, i.uv) * _Color;

                    // Obtiene el valor de oclusión del mapa de oclusión (solo canal rojo)
                    float occlusion = tex2D(_OcclusionMap, i.uv).r;

                    // Aplica la intensidad de oclusión
                    occlusion = lerp(1.0, occlusion, _OcclusionStrength);

                    // Combina el color de la textura con la oclusión para atenuar áreas sombreadas
                    float3 finalColor = texColor.rgb * occlusion;

                    return float4(finalColor, texColor.a);
                }
                ENDCG
            }
        }
            FallBack "Diffuse"
}
