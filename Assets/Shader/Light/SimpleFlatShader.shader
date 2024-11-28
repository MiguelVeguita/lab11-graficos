Shader "Custom/FlatLightingShader"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
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
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 flatNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            float4 _BaseColor;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                // Calcular la posición y la normal en el espacio mundial
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.flatNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));

                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                // Calcular la dirección de la luz
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                // Calcular la iluminación usando una normal plana
                float NdotL = max(0, dot(i.flatNormal, lightDir));

                // Multiplicar el color base por el resultado de la iluminación difusa plana
                float3 color = _BaseColor.rgb * _LightColor0.rgb * NdotL;

                return float4(color, _BaseColor.a);
            }
            ENDCG
        }
    }
        FallBack "Diffuse"
}
