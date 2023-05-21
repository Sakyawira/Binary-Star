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
        private UnityEvent<List<Sprite>, Sprite> _changeBackgroundEvent;

        [SerializeField]
        private BackgroundDatabase _backgroundDatabase;

        public string ChangeBackground(string place, string time)
        {
            ChangeBackground(place, Enum.Parse<Time>(time.ToUpper()));
            return "";
        }

        public string ChangeBackground(string place, Time time)
        {
            var sprite = _backgroundDatabase.GetSprite(place, time);
            _changeBackgroundEvent.Invoke(sprite, null);
            return "";
        }
    }
}
