// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

 Shader "Tessellation triplanar" {
        Properties {
            _EdgeLength ("Edge length", Range(2,1000)) = 15
            //_worldOffset ("offset", Float) = 0
            _rim ("rim", Float) = 0
            _rimP ("rimP", Float) = 0
            _Wsize ("Wsize", Range(0.01,10)) = 1
            _break ("break", Range(0,10)) = 1
            _nomalmapPower ("nmpower", Range(0,10)) = 1
            _dispOffset ("_dispOffset", Range(-1,1)) = 1
            _MainTex ("Base (RGB)", 2D) = "white" {}
            _DispTex ("Disp Texture", 2D) = "gray" {}
            _NormalMap ("Normalmap", 2D) = "bump" {}
            _Displacement ("Displacement", Range(0, 1.0)) = 0.3
            _Color ("Color", color) = (1,1,1,0)
            _SpecColor ("Spec color", color) = (0.5,0.5,0.5,0.5)
            _RimColor ("rim color", color) = (0.5,0.5,0.5,0.5)
        }
        SubShader {
            Tags { "RenderType"="Opaque" }
            LOD 300
            
            CGPROGRAM
            #pragma surface surf BlinnPhong addshadow fullforwardshadows vertex:disp tessellate:tessEdge nolightmap
            #pragma target 5.0
            #include "Tessellation.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            float _EdgeLength;

            float4 tessEdge (appdata v0, appdata v1, appdata v2)
            {
                return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
            }

            sampler2D _DispTex;
            float _Displacement;
            float _Wsize;
            float _dispOffset;
            float _break;
            float _nomalmapPower;
            float _worldOffset;

            void disp (inout appdata v)
            {


            		float4 pos = mul(unity_ObjectToWorld, v.vertex);

                	float norX = abs(v.normal.x);
                    float norY = abs(v.normal.y);
                    float norZ = abs(v.normal.z);
                    float total = sqrt(norX*norX + norY*norY + norZ*norZ);
                    norX /= total;
                    norY /= total;
                    norZ /= total;

                    _worldOffset *= 0.1;

                    float4 texXY = tex2Dlod(_DispTex, _Wsize*float4(pos.y,pos.z,0,0)+_worldOffset); // tex2D(Tex1, float2(pos.y,pos.z));
                    float4 result = (texXY * norX); 

                    texXY =  tex2Dlod(_DispTex, _Wsize*float4(pos.x,pos.z,0,0)+_worldOffset);
                    result += texXY * norY;

                    texXY =  tex2Dlod(_DispTex,_Wsize* float4(pos.x,pos.y,0,0)+_worldOffset);
             	    result += texXY * norZ; 

             	    v.vertex.xyz += v.normal * sin(v.tangent.x*10) * 0.01 * _break;

             	    //_Displacement *= v.uv.x;
                float d = result.a * _Displacement;
                v.vertex.xyz += v.normal * d + v.normal * _dispOffset * _Displacement;


                float3 normalmap = result.rgb; // get normal map value

                normalmap = pow(normalmap,2.22); // linear space

                normalmap = float3(normalmap.r*2-1,normalmap.g*2-1,normalmap.b); // unpack normals

                normalmap.xy *= _nomalmapPower; // wrong maths to boost or reduce normap map contribution
                normalmap.z /= _nomalmapPower;
                normalmap = normalize(normalmap); // normalize because maths is wrong

                float3 normal = v.normal; // get tangent space axis
                float3 tangent = v.tangent;
                float3 binormal = cross( v.normal, v.tangent.xyz ) * v.tangent.w; 

                float3 newnormal = float3(0,0,0); // new normal vector

                 newnormal = normal * normalmap.b;
                 newnormal += tangent * normalmap.g;
                 newnormal += binormal * normalmap.r;

                v.normal = newnormal;


                // v.normal = binormal
                //v.pos = v.vertex.xyz;
            }

            struct Input {
                float2 uv_MainTex;
                float3 pos;
                float3 viewDir;
            };

            sampler2D _MainTex;
            sampler2D _NormalMap;
            fixed4 _Color;
            fixed _RimColor;
            float _rim;
            float _rimP;

            void surf (Input IN, inout SurfaceOutput o) {

            	//float4 = o.vertex;        

                half4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
                o.Albedo = c.rgb;
                o.Specular = 0.2;
                o.Gloss = 1.0;               
                half rim = 1.0 - dot (normalize(IN.viewDir), o.Normal);
                o.Emission =  pow (rim, _rim) * _rimP;
                //o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
            }
            ENDCG
        }
        FallBack "Diffuse"
    }