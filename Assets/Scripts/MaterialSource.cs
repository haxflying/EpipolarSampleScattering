using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(menuName = "MaterialSource")]
public class MaterialSource : ScriptableObject{

    [SerializeField]
    private Shader sliceEndPointShader;

    private Material m_SliceEndPointMat;
    public Material sliceEndPointMat
    {
        get
        {
            if (m_SliceEndPointMat == null)
                m_SliceEndPointMat = new Material(sliceEndPointShader);
            return m_SliceEndPointMat;
        }
    }

    [SerializeField]
    private Shader samplerCoordsShader;

    private Material m_samplerCoordsMat;
    public Material samplerCoordsMat
    {
        get
        {
            if (m_samplerCoordsMat == null)
                m_samplerCoordsMat = new Material(samplerCoordsShader);
            return m_samplerCoordsMat;
        }
    }

    [SerializeField]
    private Shader sliceUVDirAndOriginShader;

    private Material m_sliceUVDirAndOriginMat;
    public Material sliceUVAndDirOriginMat
    {
        get
        {
            if (m_sliceUVDirAndOriginMat == null)
                m_sliceUVDirAndOriginMat = new Material(sliceUVDirAndOriginShader);
            return m_sliceUVDirAndOriginMat;
        }
    }

    [SerializeField]
    private Shader minmaxTreeShader;

    private Material m_minmaxTreeMat;
    public Material minmaxTreeMat
    {
        get
        {
            if (m_minmaxTreeMat == null)
                m_minmaxTreeMat = new Material(minmaxTreeShader);
            return m_minmaxTreeMat;
        }
    }

    [SerializeField]
    private Shader inScatteringShader;

    private Material m_inScatteringMat;
    public Material inScatteringMat
    {
        get
        {
            if (m_inScatteringMat)
                m_inScatteringMat = new Material(inScatteringShader);
            return m_inScatteringMat;
        }
    }

    [SerializeField]
    private Shader m_unwrapShader;

    private Material m_unwrapMat;
    public Material unwrapMat
    {
        get
        {
            if (m_unwrapMat == null)
                m_unwrapMat = new Material(m_unwrapShader);
            return m_unwrapMat;
        }
    }
}
