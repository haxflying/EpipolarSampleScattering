using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class ScatteringEffects : MonoBehaviour {

    public int Slices = 256, Samples;
    public MaterialSource matSource;

    private Camera cam;
    private CommandBuffer cmd;

    private RenderTexture res;

    private void Start()
    {
        cmd = new CommandBuffer();
        cmd.name = "Scattering";

        res = new RenderTexture(Screen.width, Screen.height, 0);
        res.name = "res";

        cam = GetComponent<Camera>();
        cam.depthTextureMode |= DepthTextureMode.Depth;

        cam.AddCommandBuffer(CameraEvent.BeforeImageEffects, cmd);
        print("Cb registed!");

        
    }

    private void OnPreRender()
    {
        if (cmd == null)
            return;

        cmd.Clear();
        RenderSliceEndPoint(cmd);

    }

    private void RenderSliceEndPoint(CommandBuffer cb)
    {
        int texId = Shader.PropertyToID(TextureSources.sliceEndPoints);
        Material mat = matSource.sliceEndPointMat;
        cb.GetTemporaryRT(texId, Slices, 1, 0);
        cb.SetRenderTarget(texId);
        cb.Blit(texId, texId, mat);

        cb.Blit(texId, res);
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        Graphics.Blit(res, dst);
    }
}
