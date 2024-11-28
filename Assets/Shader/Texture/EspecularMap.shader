Shader "Custom/EspecularMap" {
    Properties {
        _MainTex ("Base Color", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _SpecularMap ("Specular Map", 2D) = "white" {}
        _HeightMap ("Height Map", 2D) = "black" {}
        _OcclusionMap ("Ambient Occlusion Map", 2D) = "white" {}
        _EmissionMap ("Emissive Map", 2D) = "black" {}
        _Shininess ("Shininess", Range(0.03, 1.0)) = 0.5
    }

    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf StandardSpecular fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _NormalMap;
        sampler2D _SpecularMap;
        sampler2D _HeightMap;
        sampler2D _OcclusionMap;
        sampler2D _EmissionMap;
        half _Shininess;

        struct Input {
            float2 uv_MainTex;
            float2 uv_NormalMap;
            float2 uv_SpecularMap;
            float2 uv_HeightMap;
            float2 uv_OcclusionMap;
            float2 uv_EmissionMap;
        };

        void surf (Input IN, inout SurfaceOutputStandardSpecular o) {
            // Textura base
            fixed4 mainTex = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = mainTex.rgb;

            // Normal Map
            fixed4 normalMap = tex2D(_NormalMap, IN.uv_NormalMap);
            o.Normal = UnpackNormal(normalMap);

            // Specular Map
            fixed4 specularMap = tex2D(_SpecularMap, IN.uv_SpecularMap);
            o.Specular = specularMap.r; // Usa el canal rojo del Specular Map
            o.Smoothness = _Shininess;

            // Ambient Occlusion Map
            fixed4 aoMap = tex2D(_OcclusionMap, IN.uv_OcclusionMap);
            o.Occlusion = aoMap.r; // Usa el canal rojo para AO

            // Emissive Map
            fixed4 emissionMap = tex2D(_EmissionMap, IN.uv_EmissionMap);
            o.Emission = emissionMap.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
