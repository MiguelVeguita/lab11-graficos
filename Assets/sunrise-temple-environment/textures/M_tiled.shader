Shader "Custom/CombinedTextureMapsShader" {
    Properties {
        _MainTex ("Base Color", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _SpecularMap ("Specular Map", 2D) = "white" {}
        _HeightMap ("Height Map", 2D) = "black" {}
        _OcclusionMap ("Ambient Occlusion Map", 2D) = "white" {}
        _EmissionMap ("Emissive Map", 2D) = "black" {}
        _HeightScale ("Height Scale", Range(0, 0.1)) = 0.05
    }

    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 300

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _NormalMap;
            sampler2D _SpecularMap;
            sampler2D _HeightMap;
            sampler2D _OcclusionMap;
            sampler2D _EmissionMap;
            float _HeightScale;

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v) {
                v2f o;

                // Pasar solo la posición y los datos de normales/UV
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = mul(unity_ObjectToWorld, float4(v.normal, 0.0)).xyz;
                o.pos = UnityObjectToClipPos(v.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                // Obtener valores de las texturas
                fixed4 albedo = tex2D(_MainTex, i.uv);
                fixed3 normal = UnpackNormal(tex2D(_NormalMap, i.uv));
                fixed4 specular = tex2D(_SpecularMap, i.uv);
                fixed4 ao = tex2D(_OcclusionMap, i.uv);
                fixed4 emission = tex2D(_EmissionMap, i.uv);

                // Calculando el parallax mapping en el fragment shader (más adecuado para este tipo de operaciones)
                float height = tex2D(_HeightMap, i.uv).r * _HeightScale;
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                i.uv += viewDir.xy * height;

                // Cálculos de luz y reflexión
                fixed3 lightDir = normalize(float3(0, 0, 1));
                fixed3 viewDirFragment = normalize(_WorldSpaceCameraPos - i.worldPos);
                fixed3 halfDir = normalize(lightDir + viewDirFragment);

                // Reflexión especular
                fixed3 reflectance = specular.rgb * pow(max(dot(normal, halfDir), 0.0), 64);

                // Resultado final
                fixed3 finalColor = albedo.rgb * ao.r + reflectance + emission.rgb;
                return fixed4(finalColor, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
