Shader "Custom/LambertNoTexture"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
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
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float4 pos : SV_POSITION;
            };

            float4 _Color;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                // Color base del material
                float3 baseColor = _Color.rgb;

                // Cálculo de la iluminación difusa usando el modelo de Lambert
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);

                float NdotL = max(0, dot(i.worldNormal, lightDir));

                // Color difuso basado en el producto escalar
                float3 diffuse = baseColor * _LightColor0.rgb * NdotL ;

                return float4(diffuse, _Color.a);
            }
            ENDCG
        }
    }
        FallBack "Diffuse"
}
