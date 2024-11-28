Shader "Custom/AmbientLightShader"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _AmbientColor("Ambient Color", Color) = (0.5, 0.5, 0.5, 1)
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

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
            };

            float4 _Color;
            float4 _AmbientColor; // Color de luz ambiental

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                // Aplicación de la luz ambiental
                float3 color = _Color.rgb * _AmbientColor.rgb;
                return float4(color, _Color.a);
            }
            ENDCG
        }
    }
        FallBack "Diffuse"
}
