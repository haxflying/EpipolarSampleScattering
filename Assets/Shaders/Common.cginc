uint SliceNum;
uint SamplerNum;

float4 GetOutermostScreenPixelCoords()
{
	//return float4(-1,-1,1,1) + float4(1,1,-1,-1) / _ScreenParams.xyxy;
	return float4(0, 0, 1, 1) + float4(1, 1, -1, -1) * 0.5 / _ScreenParams.xyxy;
}
