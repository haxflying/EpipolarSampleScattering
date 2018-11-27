Shader "Hidden/ScatteringRaymarch"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D tex2DSamplerCoords;
			UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

			inline float3 computeCameraSpacePosFromDepthAndInvProjMat(v2f i)
			{
			    float zdepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv.xy);

			    #if defined(UNITY_REVERSED_Z)
			        zdepth = 1 - zdepth;
			    #endif

			    // View position calculation for oblique clipped projection case.
			    // this will not be as precise nor as fast as the other method
			    // (which computes it from interpolated ray & depth) but will work
			    // with funky projections.
			    float4 clipPos = float4(i.uv.zw, zdepth, 1.0);
			    clipPos.xyz = 2.0f * clipPos.xyz - 1.0f;
			    float4 camPos = mul(unity_CameraInvProjection, clipPos);
			    camPos.xyz /= camPos.w;
			    camPos.z *= -1;
			    return camPos.xyz;
			}

			float3 ProjToWorld(float3 pos)
			{
				return 0;
			}

			fixed4 frag (v2f i) : SV_Target
			{				
				float3 sampleLocation = tex2D(tex2DSamplerCoords, i.uv);
				float3 rayEnd = ProjToWorld(sampleLocation);
				float3 fullRay = rayEnd - _WorldSpaceCameraPos.xyz;
				float rayLength = length(fullRay);
				float3 viewDir = fullRay / rayLength;
				
			}
			ENDCG
		}
	}
}
