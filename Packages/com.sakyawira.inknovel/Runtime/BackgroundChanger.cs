using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace Sakyawira.InkNovel
{
    public class BackgroundChanger : MonoBehaviour
    {
        [SerializeField]
        private UnityEvent<Sprite> _changeBackgroundEvent;

        [SerializeField]
        private BackgroundDatabase _backgroundDatabase;

        public Func<string, string, string> ChangeBackground;

        public void Awake()
        {
            ChangeBackground += ChangeBackgroundImpl;
        }

        public string ChangeBackgroundImpl(string place, string time)
        {
            try
            {
                var sprite = _backgroundDatabase.GetSprite(place, Enum.Parse<Time>(time.ToUpper()));
                _changeBackgroundEvent.Invoke(sprite);
                return "";
            }
            catch(Exception e)
            {

            }
            return "";
        }
    }
}
