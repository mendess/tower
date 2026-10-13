#!/usr/bin/env python3
"""Read entity variables as JSON from stdin and print cover positions as JSON."""

import json
from json.encoder import INFINITY
import sys
from itertools import chain

if len(sys.argv) < 2:
    print("missing required argument, entity state")
    exit(1)

entities = json.loads(sys.argv[1])

azimuth = entities["azimuth"]
elevation = entities["elevation"]
daytime = entities["daytime"]
max_temp = entities["max_temp"]
weather = entities["weather"]
rainy = weather in ["pouring", "rainy"]
cloudy = rainy or weather in ["fog", "cloudy"]
gaming = entities["gaming"]
tolaria_on = entities["tolaria_on"]
oboro_on = entities["oboro_on"]
jellyfin = entities["jellyfin"]
youtube = entities["youtube"]
sleeping = entities["sleeping"]
privacy = entities["privacy"]
balcony_open = entities["balcony_open"]
desk_raised = entities["desk_raised"]


def sun_bounding_box(
    elevation_limits: tuple[float, float], azimuth_limits: tuple[float, float]
):
    return (
        elevation_limits[0] < elevation < elevation_limits[1]
        and azimuth_limits[0] < azimuth < azimuth_limits[1]
    )


sun = {
    "east": {
        "base": sun_bounding_box(
            elevation_limits=(0, INFINITY), azimuth_limits=(0, 220)
        ),
        "blinding": sun_bounding_box(
            elevation_limits=(15, 20), azimuth_limits=(0, 200)
        ),
    },
    "south": {
        "base": sun_bounding_box(
            elevation_limits=(0, INFINITY), azimuth_limits=(100, 260)
        ),
        "tv": sun_bounding_box(
            elevation_limits=(31.17, INFINITY), azimuth_limits=(138.44, 178)
        ),  # TODO
    },
    "west": {
        "base": sun_bounding_box(
            elevation_limits=(0, INFINITY), azimuth_limits=(200, INFINITY)
        ),
        "blinding": sun_bounding_box(
            elevation_limits=(5, 28), azimuth_limits=(200, INFINITY)
        ),
        "sunset": sun_bounding_box(
            elevation_limits=(-7, 1), azimuth_limits=(200, INFINITY)
        ),
    },
}

tolaria_gaming = not gaming and tolaria_on
at_my_desk = tolaria_gaming or oboro_on

if max_temp < 27.5:
    target_lower = 100
elif max_temp < 30 and cloudy:
    target_lower = 70
else:
    target_lower = 30

morning_blind = sun["east"]["blinding"] and not cloudy
eod_blinding = sun["west"]["blinding"] and not cloudy
eod_brightness = sun["west"]["blinding"] and cloudy

target = {
    # general
    "daytime": 0 if not daytime else 100,
    "sleeping": 0 if sleeping else 100,
    # base lower targets
    "lower_east": (
        (0 if target_lower == 30 else target_lower) if sun["east"]["base"] else 100
    ),
    "lower_south": target_lower if sun["south"]["base"] else 100,
    "lower_west": target_lower if sun["west"]["base"] else 100,
    # living room
    "tv_sun_shine": 30 if (jellyfin or youtube) and sun["south"]["tv"] else 100,
    "media": 0 if gaming or jellyfin else 100,
    "privacy": 30 if privacy else 100,
    "blind": 70 if morning_blind else 100,
    # study/bedroom
    "desk_sunny": (10 if desk_raised else 30) if at_my_desk and not rainy else 100,
    "sun_blinded": (5 if desk_raised else 7) if at_my_desk and eod_blinding else 100,
    "sun_bright": 35 if at_my_desk and eod_brightness else 100,
    "desk_cloudy": 60 if at_my_desk and rainy else 100,
}
override = {
    "doors_open": 70 if balcony_open else 0,
    "sunset": 70 if sun["west"]["sunset"] else 0,
}


class Position:
    def __init__(self, base, override=[0]):
        def normalize(value) -> list[float]:
            items = value if isinstance(value, list) else [value]
            return list(
                chain.from_iterable(
                    item if isinstance(item, list) else [item] for item in items
                )
            )

        self.base = normalize(base)
        self.override = normalize(override)

    def calc(self):
        return max(min(self.override), min(self.base))


pos_all = Position(base=[target["daytime"], target["sleeping"]])

pos_tv_covers = Position(
    base=[
        pos_all.base,
        target["lower_south"],
        target["tv_sun_shine"],
        target["privacy"],
        target["media"],
    ],
)
pos_varanda = Position(
    base=[
        pos_all.base,
        target["lower_east"],
        target["privacy"],
        target["media"],
        target["blind"],
    ],
    override=[override["doors_open"]],
)
pos_bedroom_wc = Position(
    base=[pos_all.base, target["lower_south"]],
)
pos_bedroom = Position(
    base=[pos_all.base, target["lower_west"]],
    override=override["sunset"],
)
pos_study = Position(
    base=[
        pos_bedroom.base,
        target["desk_sunny"],
        target["desk_cloudy"],
        target["sun_blinded"],
        target["sun_bright"],
    ],
    override=pos_bedroom.override,
)


json.dump(
    {
        "dbg": {
            "target": target,
            "override": override,
        },
        "tv_covers": pos_tv_covers.calc(),
        "varanda": pos_varanda.calc(),
        "bedroom_wc": pos_bedroom_wc.calc(),
        "bedroom": pos_bedroom.calc(),
        "study": pos_study.calc(),
    },
    sys.stdout,
)
