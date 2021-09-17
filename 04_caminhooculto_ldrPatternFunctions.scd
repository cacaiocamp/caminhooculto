(
{
	~funcInstantiateLDRPatterns = {
		~ldrPatternsDisplays.do({
			arg ldrPatternDisplay, ldrPatternDisplayIndex;
			var newLDRpattern;

			newLDRpattern = ~ldrPatternEventClassStructure.value(
				patternIndex: ldrPatternDisplayIndex,
				patternDisplayArray: ldrPatternDisplay
			);

			~vecLDRPatterns = ~vecLDRPatterns.add(newLDRpattern);
		});
	};
}.fork(SystemClock);
)