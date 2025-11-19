# Yelb

You even lift, Bro?

A workout/Gym tracker flutter application.

## Scope

The point is to replace writing down my gym sessions in notes.

Usual data looks somehting like this:

    Basic-fit workout - Push A - dd/mm/yyyy

        warm-up/stretch

        [Chest]

        {barbell} bench press
            12x 75
            10x 77,5
            8x 80
            6x 82,5
            4x 85

            superset: 8x 70

        {barbell} inclined chest press
            12x 50
            10x 55
            8x 60

        [Shoulder]

        {barbell} shoulder press
            12x 30
            10x 35
            8x 40

        {dungbell} lateral raises
            10x 8
                ss: 10x 5
            10x 8
                ss: 8x 5
            8x 8
                ss: 10x 5
            
        [Arms]

        {cable} triceps pulldowns
            12x 30
            12x 30
            12x 30

        dips
            14
            12
            10
    
The point would be to create an app that can save a series of excercises, as to easily create workouts with custom excercises and the correct reps/weights/sets and save them.
The db would be local but might be extended to a firestore.


