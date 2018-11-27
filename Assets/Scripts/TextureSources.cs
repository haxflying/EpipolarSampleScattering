using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TextureSources {

    public static string sliceEndPoints = "tex2DSliceEndPoints";
    public static string samplerCoords = "tex2DSamplerCoords";
    public static string sliceUVDirAndOrigin = "tex2DSliceUVDirAndOrigin";
    public static string minMaxTree = "tex2DminmaxTree";
    public static string shadowmap_Copy = "tex2DShadowmapCopy";
    public static string minmaxTemp = "tex2DminmaxTemp";
    public static string inScattering = "tex2DInsctr";
    public static string unWrapping = "tex2DUnwrap";
}


public enum RenderRes
{
    sliceEndPoints,
    samplerCoords,
    sliceUVDirAndOrigin,
    minMaxTree,
    shadowmap_Copy
}