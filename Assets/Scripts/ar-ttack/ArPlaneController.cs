using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

[RequireComponent(typeof(ARRaycastManager))]
public class ArPlaneController : MonoBehaviour
{
    [SerializeField] private GameObject planeObject;
    [SerializeField] private ARCameraBackground arCameraBackground;
    [SerializeField] private RenderTexture renderTexture;
    private GameObject generateObject;
    private ARRaycastManager raycastManager;
    private static List<ARRaycastHit> hits = new List<ARRaycastHit>();

    void Awake()
    {
        raycastManager = GetComponent<ARRaycastManager>();
    }

    void Update()
    {
        if (generateObject)
        {
            UpdateObjectTexture();
        }
        if (Input.touchCount > 0)
        {
            Vector2 touchPosition = Input.GetTouch(0).position;
            if (raycastManager.Raycast(touchPosition, hits, TrackableType.PlaneWithinPolygon))
            {
                var hitPose = hits[0].pose;
                generateObject = Instantiate(planeObject, hitPose.position, hitPose.rotation);
                /*
                if (generateObject)
                {
                    generateObject.transform.position = hitPose.position;
                }
                else
                {
                    generateObject = Instantiate(planeObject, hitPose.position, Quaternion.identity);
                }
                */
            }
        }
    }

    private void UpdateObjectTexture()
    {
        Graphics.Blit(null, renderTexture, arCameraBackground.material);
    }
}