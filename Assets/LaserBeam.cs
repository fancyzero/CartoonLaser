using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LaserBeam : MonoBehaviour
{
    Mesh mesh;
    public int textureSize;
    public CustomRenderTexture VertInfoTexture = null;
    public Texture2D tex;
    public Shader initShader;
    public Vector2 start=Vector2.zero;
    public Vector2 end = Vector2.up;
    public float Length
    {
        get
        {
            return (start - end).magnitude;
        }
        set
        {
            end = start + Dir * value;
        }
    }
    public Vector2 Dir
    {
        get { return (end - start).normalized; }
        set { end = start + value * Length; }
    }

    public float width;
    public float segmentSize;
    // Start is called before the first frame update
    void Start()
    {
        mesh = new Mesh();
        var verts = new List<Vector3>();
        var indices = new List<int>();
        var uvs = new List<Vector2>();
        var uvs2 = new List<Vector2>();
        var uvs3 = new List<Vector2>();
        int cnt = 32;
        for ( int i=0;i < cnt; i++)
        {
            int prev = i - 1;
            int next = i + 1;
            int cur = i;

            verts.Add(Vector3.zero);
            verts.Add(Vector3.zero);
            uvs.Add(new Vector2(i, 1));//x : index, y: left or right
            uvs.Add(new Vector2(i, -1));
        }

        for (int i = 0; i < cnt-1 ; i++)
        {
            indices.Add(0 + i * 2);
            indices.Add(1 + i * 2);
            indices.Add(2 + i * 2);
            indices.Add(1 + i * 2);
            indices.Add(2 + i * 2);
            indices.Add(3 + i * 2);

        }


        tex = new Texture2D(textureSize, textureSize,UnityEngine.Experimental.Rendering.GraphicsFormat.R16G16B16A16_SFloat, 0);

        for (int i = 0; i < cnt; i++)
        {
            var pos = Vector2.Lerp( start, end, i / (float)(cnt - 1));
            tex.SetPixel(i % textureSize, i / textureSize,new Color(pos.x,pos.y,0));
        }
        tex.Apply();
        
        mesh.SetVertices(verts);
        mesh.SetUVs(0, uvs);
        mesh.SetIndices(indices.ToArray(), MeshTopology.Triangles, 0);
        GetComponent<MeshFilter>().mesh = mesh;
        VertInfoTexture = new CustomRenderTexture(textureSize, textureSize, RenderTextureFormat.ARGB64, RenderTextureReadWrite.Linear);

        VertInfoTexture.initializationTexture = tex;
        VertInfoTexture.initializationSource = CustomRenderTextureInitializationSource.TextureAndColor;
        VertInfoTexture.initializationMode = CustomRenderTextureUpdateMode.OnDemand;
        VertInfoTexture.updateMode = CustomRenderTextureUpdateMode.OnDemand;
        //initMat.SetVector("_start", start);
        //initMat.SetVector("_end", end);
        //initMat.SetInt("_points", cnt);

    }
    int initcount = 2;
    // Update is called once per frame
    void Update()
    {
            
        if(initcount > 0)
        {
            Debug.Log("init");

            VertInfoTexture.Initialize();
            initcount--;

        }
        width -= Time.deltaTime * 0.03f;
        if (width < 0)
            width = 0;
        GetComponent<MeshFilter>().mesh.bounds = new Bounds(Vector3.zero, Vector3.one * 100000);
        GetComponent<MeshRenderer>().material.SetFloat("_psize", width);
        //GetComponent<MeshRenderer>().enabled = Random.Range(0, 1.0f) > 0.4f;


    }
}
