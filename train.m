function train()
   configData;
   hmmTraining_fe(config.trainingFolder, config );
   organizeObservationsPerWord( config.trainingFolder, config.vocabulary, config.featureType, config.modelFolder );
   trainHmm( config.modelFolder, 'one', 2, 2 );
   trainHmm( config.modelFolder, 'two', 2, 2 );
   trainHmm( config.modelFolder, 'three', 3, 2 );
   trainHmm( config.modelFolder, 'four', 2, 2 );
end