using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

[System.Serializable]
public class ButtonPrefabMapping
{
    public Button button;
    public GameObject shapeObject;
}

[RequireComponent(typeof(ARRaycastManager))]
public class ArPlaneController : MonoBehaviour
{
    [SerializeField] private List<ButtonPrefabMapping> mappings;
    [SerializeField] private ARCameraBackground arCameraBackground;
    [SerializeField] private RenderTexture renderTexture;
    private GameObject generateObject;
    private ARRaycastManager raycastManager;
    private static List<ARRaycastHit> hits = new List<ARRaycastHit>();
    private GameObject planeObject;

    void Awake()
    {
        raycastManager = GetComponent<ARRaycastManager>();
        foreach (var mapping in mappings)
        {
            mapping.button.onClick.AddListener(() => SetPrefab(mapping.shapeObject));
        }
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
            }
        }
    }

    private void UpdateObjectTexture()
    {
        Graphics.Blit(null, renderTexture, arCameraBackground.material);
    }

    public void SetPrefab(GameObject shapeObject)
    {
        planeObject = shapeObject;
    }
}