using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using UnityEngine;

public class ChangeCamera : MonoBehaviour
{
    [SerializeField]
    private CinemachineVirtualCamera _startCamera;
    [SerializeField]
    private CinemachineVirtualCamera _endCamera;

    public void SwapCamera()
    {
        _startCamera.gameObject.SetActive(!_startCamera.gameObject.activeInHierarchy);
        _endCamera.gameObject.SetActive(!_endCamera.gameObject.activeInHierarchy);
    }
}
