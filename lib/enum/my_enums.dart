enum InstrumentType {
  stakingTool('Staking Tool'),
  depthingTool('Depthing Tool'),
  mainspringWinder('Mainspring Winder'),
  poiseScale('Poise Scale'),
  watchTimingMachine('Watch-Timing Machine'),
  marineChronometerTester('Marine Chronometer Tester'),
  masterClock('Master Clock'),
  transitInstrument('Transit Instrument'),
  ratingScale('Rating Scale');

  const InstrumentType(this.label);
  final String label;
}

enum OperatingPrinciple {
  mechanical('Mechanical (lever-action)'),
  gravityBased('Gravity-Based (pendulum test)'),
  earlyElectronic('Early Electronic (vacuum tube timing)');

  const OperatingPrinciple(this.label);
  final String label;
}

enum CountryOfOrigin {
  england('England'),
  switzerland('Switzerland'),
  usa('USA'),
  france('France'),
  germany('Germany');

  const CountryOfOrigin(this.label);
  final String label;
}

enum ConditionState {
  operational('Operational'),
  originalFinish('Original Finish'),
  jewelIntegrity('Jewel Integrity'),
  museumQuality('Museum Quality'),
  unknown('Condition Unknown');

  const ConditionState(this.label);
  final String label;
}
