using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class ScatteringEffects : MonoBehaviour {

    public Shader debugShader;
    private Material debugMat;

    public int Slices = 256, Samples;
    public Light mainLight;
    public MaterialSource matSource;


    private Camera cam;
    private CommandBuffer cmd, sm_cpy;

    private RenderTexture res;

    public int Cascades
    {
        get
        {
            return QualitySettings.shadowCascades;
        }
    }

    private void Start()
    {
        if (mainLight == null)
            return;

        cmd = new CommandBuffer();
        cmd.name = "Scattering";

        res = new RenderTexture(Screen.width, Screen.height, 0);
        res.name = "res";

        cam = GetComponent<Camera>();
        cam.depthTextureMode |= DepthTextureMode.Depth;

        cam.AddCommandBuffer(CameraEvent.BeforeImageEffects, cmd);

        sm_cpy = new CommandBuffer();
        sm_cpy.name = "Shadowmap copy";
        mainLight.AddCommandBuffer(LightEvent.AfterShadowMap, sm_cpy);
        
        print("Cb registed!");

        debugMat = new Material(debugShader);


        InitVariable();
    }

    private void OnPreRender()
    {
        if (sm_cpy == null)
            return;

        int shadowmap = -1;
        CopyShadowmap(sm_cpy, ref shadowmap);

        if (cmd == null)
            return;

        cmd.Clear();
        RenderSliceEndPoint(cmd);
        RenderSamplerCoords(cmd);
        RenderSliceSMDirAndOrigin(cmd);     
    }

    private void InitVariable()
    {
        Shader.SetGlobalInt("SliceNum", Slices);
        Shader.SetGlobalInt("SamplerNum", Samples);
    }

    private void RenderSliceEndPoint(CommandBuffer cb)
    {
        int texId = Shader.PropertyToID(TextureSources.sliceEndPoints);
        Material mat = matSource.sliceEndPointMat;
        cb.GetTemporaryRT(texId, Slices, 1, 0);
        cb.SetRenderTarget(texId);
        cb.Blit(texId, texId, mat);
        
    }

    private void RenderSamplerCoords(CommandBuffer cb)
    {
        int texId = Shader.PropertyToID(TextureSources.samplerCoords);
        Material mat = matSource.samplerCoordsMat;
        cb.GetTemporaryRT(texId, Samples, Slices, 0, FilterMode.Point, RenderTextureFormat.ARGB32);
        cb.SetRenderTarget(texId);
        cb.Blit(texId, texId, mat);
     
    }

    private void RenderSliceSMDirAndOrigin(CommandBuffer cb)
    {
        int texId = Shader.PropertyToID(TextureSources.sliceUVDirAndOrigin);
        Material mat = matSource.sliceUVAndDirOriginMat;
        //1 cascade for convinient
        cb.GetTemporaryRT(texId, Slices, 1);
        cb.Blit(texId, texId, mat);

        cb.Blit(texId, res);
    }

    private void CopyShadowmap(CommandBuffer cb, ref int shadowMap_Copy)
    {
        shadowMap_Copy = Shader.PropertyToID(TextureSources.shadowmap_Copy);
        RenderTargetIdentifier shadowmap = BuiltinRenderTextureType.CurrentActive;
        cb.SetShadowSamplingMode(shadowmap, ShadowSamplingMode.RawDepth);
        cb.Blit(shadowmap, shadowMap_Copy);
    }

    private void ConstructMinMaxTree(CommandBuffer cb, int shadowmap)
    {
        int sm_res = 1024;
        RenderTexture minmax0 = RenderTexture.GetTemporary(sm_res, sm_res);
        RenderTexture minmax1 = RenderTexture.GetTemporary(sm_res, sm_res);

        RenderTexture[] minmaxs = new RenderTexture[] { minmax0, minmax1 };
        int parity = 0;
        int preXOffset = 0;
        int XOffset = 0;
        for (int step = 2; step < 7; step *= 2, parity = (parity + 1) % 2)
        {
            cb.SetRenderTarget(minmaxs[parity]);
            cb.SetGlobalInt("_SrcXOffset", preXOffset);
            cb.SetGlobalInt("_DstXOffset", XOffset);

            if(step == 2)
            {
                cb.SetGlobalTexture("tex2DminmaxSource", shadowmap);
            }
            else
            {
                cb.SetGlobalTexture("tex2DminmaxSource", minmaxs[(parity + 1) % 2]);
            }

            Rect viewport = new Rect(XOffset, 0, sm_res / step, sm_res);
            cb.SetViewport(viewport);
            cb.Blit(null, BuiltinRenderTextureType.CurrentActive);
            
            if(parity == 1)
            {
                cb.CopyTexture(minmax1, 0, 0, XOffset, 0, sm_res / step, sm_res,
                    minmax0, 0, 0, XOffset, 0);
            }

            preXOffset = XOffset;
            XOffset += sm_res / step;
        }
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        Graphics.Blit(res, dst, debugMat);
    }
}
