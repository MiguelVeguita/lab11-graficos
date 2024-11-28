Shader "Unlit/MultTextUnlitShader"
{
    Properties
    {
        _MainTexA ("TextureA", 2D) = "white" {}
        _MainTexB("TextureB", 2D) = "white" {}
        _Mask("Mask", 2D) = "white" {}
        _Blend("Blend", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode" = "ForwardAdd"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

            };
           /* struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float4 tangent : TANGENT;
            };*/
            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTexA;
            float4 _MainTexA_ST;

            sampler2D _MainTexB;
            float4 _MainTexB_ST;

            sampler2D _Mask;
            float4 _Mask_ST;

            fixed _Blend;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTexA);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 colA = tex2D(_MainTexA, i.uv);
                // sample the texture
                fixed4 colB = tex2D(_MainTexB, i.uv);

                fixed4 mask = tex2D(_Mask, i.uv);
                if(mask.r==0 && mask.g == 0 && mask.b == 0)
                  return lerp(colA, colB, _Blend) ;
                return colB;
            }
            ENDCG
        }
    }
}
