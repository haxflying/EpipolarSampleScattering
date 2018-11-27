Shader "Hidden/SliceUVDirAndOrigin"
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
				float3 ray : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.ray = mul(unity_CameraInvProjection, float4((float2(v.uv.x, v.uv.y) - 0.5) * 2, 1, -1));
				return o;
			}
			
			sampler2D _MainTex;
			UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
			//slices * 1
			sampler2D tex2DSliceEndPoints;

			inline float3 computeCameraSpacePosFromDepth(float2 pos, v2f i)
			{
				float zdepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, pos);
				float depth = Linear01Depth(zdepth);

				float vpos = i.ray * depth;
				return vpos;
			}

			//target slices * cascade (1)
			fixed4 frag (v2f i) : SV_Target
			{
				i.ray *= i.ray * (_ProjectionParams.z / i.ray.z);;
				uint cascade = 1;//i.uv.y;
				float4 startEnd = tex2D(tex2DSliceEndPoints, float2(i.uv.x, cascade));

				float3 startVS = computeCameraSpacePosFromDepth(startEnd.xy, i);
				float3 startWS = mul(unity_CameraToWorld, float4(startVS, 1)).xyz;
				float2 startSS = mul(unity_WorldToShadow[cascade - 1], float4(startWS, 1.0));

				float3 endVS = computeCameraSpacePosFromDepth(startEnd.zw, i);
				float3 endWS = mul(unity_CameraToWorld, float4(endVS, 1)).xyz;
				float2 endSS = mul(unity_WorldToShadow[cascade - 1], float4(endWS, 1.0));

				return float4(startSS, normalize(endSS - startSS));
			}
			ENDCG
		}
	}
}
