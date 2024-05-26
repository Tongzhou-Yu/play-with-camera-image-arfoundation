using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[System.Serializable]
public class ButtonSceneMapping
{
    public Button button;
    public string sceneName;
}

public class ChangeScene : MonoBehaviour
{
    public List<ButtonSceneMapping> buttonSceneMappings;

    private void Start()
    {
        foreach (var mapping in buttonSceneMappings)
        {
            mapping.button.onClick.AddListener(() => ChangeToScene(mapping.sceneName));
        }
    }

    public void ChangeToScene(string sceneName)
    {
        UnityEngine.SceneManagement.SceneManager.LoadScene(sceneName);
    }
}