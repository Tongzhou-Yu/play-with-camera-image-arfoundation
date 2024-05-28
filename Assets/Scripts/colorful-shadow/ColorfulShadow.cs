using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.ARFoundation;

[RequireComponent(typeof(ARRaycastManager))]
public class ColorfulShadow : MonoBehaviour
{
    [SerializeField]
    AROcclusionManager arHumanOcc;
    [SerializeField]
    ARCameraBackground arCamBg;
    [SerializeField]
    GameObject planePrefab;
    [SerializeField]
    float planeDistance;

    ARRaycastManager raycastManager;
    List<ARRaycastHit> hitResults = new List<ARRaycastHit>();
    RenderTexture capturedTex;
    RenderTexture humanTex;
    bool saved = false;
    float FovTanValue = 1.0f;
    [SerializeField]
    float FovRatio = 1.1f;

    void Start()
    {
        raycastManager = GetComponent<ARRaycastManager>();
        capturedTex = new RenderTexture(Screen.width, Screen.height, 0);
        /*
        [4.1.3] - 2021-01-05 - Changes
        The ARCameraBackground component now sets the camera's field of view. Because the ARCameraBackground already overrides the camera's projection matrix, this has no effect on ARFoundation. However, any code that reads the camera's fieldOfView property will now read the correct value.
        But there is no way to get the correct value of the field of view from the ARCameraBackground component. So I have to calculate it manually with FovRatio.
        */
        float FovInRadians = Camera.main.fieldOfView * Mathf.Deg2Rad * FovRatio;
        FovTanValue = Mathf.Tan(FovInRadians / 2);
    }

    public void SaveTex()
    {
        Graphics.Blit(null, capturedTex, arCamBg.material);
        Graphics.Blit(arHumanOcc.humanStencilTexture, capturedTex);
    }

    void Update()
    {
        if (Input.touchCount > 0)
        {
            Touch touch = Input.GetTouch(0);
            if (touch.phase == TouchPhase.Began)
            {
                SaveTex();
                var plane = Instantiate(planePrefab, Camera.main.transform.position + Camera.main.transform.forward * planeDistance, Camera.main.transform.rotation);
                float aspect = capturedTex.width / (float)capturedTex.height;
                float height = planeDistance * FovTanValue * 2;
                float width = height * aspect;
                plane.transform.localScale = new Vector3(height, width, 1);
                var mat = plane.GetComponentInChildren<Renderer>().material;
                mat.mainTexture = capturedTex;
                plane.transform.Rotate(0, 0, -90);
                plane.transform.Rotate(180, 0, 0);
            }
        }
    }
}

