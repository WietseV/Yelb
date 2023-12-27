enum WorkoutType {
  push('Push'),
  pull('Pull'),
  arms('Arms'),
  chest('Chest'),
  shoulders('Shoulders'),
  abs('Abs'),
  back('Back'),
  legs('Legs');

  const WorkoutType(this.type);
  final String type;
}

enum WorkoutLocation {
  fitness('Fitness Workout'),
  home('Home Workout'),
  outdoor('Outdoor Workout');

  const WorkoutLocation(this.location);
  final String location;
}

enum ExerciseName {
  bench('Bench Press'),
  inclinedBench('Inclined Bench Press'),
  chestFly('Chest Flies'),
  shoulder('Shoulder Press'),
  lateralRaise('Lateral Raises'),
  tricepsPulldown('Triceps pulldown'),
  tricepsPullover('Triceps pullover'),
  skullCrushers('Skull Crushers'),
  dips('Dips'),
  row('Row'),
  lateralPull('Lateral Pull-down'),
  delt('Rear delts'),
  pullUp('Pull-ups'),
  pushUp('Push-ups'),
  burpees('Burpees'),
  crunches('Crunches'),
  legRaises('Leg Raises'),
  sitUp('Sit-ups'),
  bicepscurl('Biceps Curl'),
  squat('Squats'),
  deadlift('Deadlift'),
  romanian('Romanian Deadlift'),
  legCurl('Leg Curls'),
  legPress('Leg Press'),
  calfPress('Calf press');

  const ExerciseName(this.name);
  final String name;
}

enum ExerciseType {
  barbell('Barbell'),
  dumbell('Dumbell'),
  cable('Cable'),
  kettlebell('Kettlebell'),
  machine('Machine'),
  bodyWeight('Bodyweight');

  const ExerciseType(this.type);
  final String type;
}
