using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class ScatteringEffects : MonoBehaviour {

    public int Slices, Samples;
    public MaterialSource matSource;

    private Camera cam;
    private CommandBuffer cmd;

    private void Start()
    {
        cmd = new CommandBuffer();
        cmd.name = "Scattering";

        cam = GetComponent<Camera>();
        cam.depthTextureMode |= DepthTextureMode.Depth;

        cam.AddCommandBuffer(CameraEvent.BeforeImageEffects, cmd);
        print("Cb registed!");

        RenderSliceEndPoint(cmd);
    }


    private void RenderSliceEndPoint(CommandBuffer cb)
    {
        int texId = Shader.PropertyToID(TextureSources.sliceEndPoints);
        Material mat = matSource.sliceEndPointMat;
        cb.GetTemporaryRT(texId, Slices, 1, 0);
        cb.SetRenderTarget(texId);
        cb.Blit(null, texId, mat);
    }
}
