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
}
