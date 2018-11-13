using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(menuName = "MaterialSource")]
public class MaterialSource : ScriptableObject{

    public Shader sliceEndPointShader;

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
}
