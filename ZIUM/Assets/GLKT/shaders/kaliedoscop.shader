Shader "Custom/kaliedoscop" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Angle1 ("angle 1", Range(-1.5707,1.5707)) = 0.0
		_Angle2 ("angle 2", Range(-1.5707,1.5707)) = 0.0
		_Reverse ("flip side", Range(-0.1,0.1)) = 0
		_gain ("color gain", Range(0,10)) = 0
		_offset ("color offset", Range(0,10)) = 0
		_WOffset ("world offset", Vector) = (0,0,0,0)
	}
	SubShader {
		Tags { "RenderType"="Transparent" }
		LOD 200
		Cull Off
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
			float3 worldPos;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		fixed4 _WOffset;
		fixed _offset;
		half _Angle1;
		half _Angle2;
		half _Reverse;	
		half _gain;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			float x = IN.worldPos.x - _WOffset.x;
			float z = IN.worldPos.z - _WOffset.z;
			
			float a = _Angle1;
			float b = _Angle2;			
			float r = _Reverse;			
			clip ( min ( (x*tan(a)-z) * -(x*tan(b)-z) , r*x));
			
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb * _gain - _offset;

			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}