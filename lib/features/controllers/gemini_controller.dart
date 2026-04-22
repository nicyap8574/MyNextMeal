import 'package:firebase_ai/firebase_ai.dart';

class GeminiController{


  //JSON format for output
  static final analysisJsonSchema = Schema.object(
      properties: {
        'nutrients': Schema.array(
            items: Schema.object(
                properties: {
                  'meal_name': Schema.string(),
                  'detected_ingredients': Schema.array(
                    items: Schema.string(),
                  ),
                  'carbs_macro': Schema.enumString(enumValues: ['Low', 'Medium', 'High', 'Unknown']),
                  'protein_macro': Schema.enumString(enumValues: ['Low', 'Medium', 'High', 'Unknown']),
                  'fats_macro': Schema.enumString(enumValues: ['Low', 'Medium', 'High', 'Unknown']),
                  'meal_healthiness': Schema.enumString(enumValues: ['Unhealthy', 'Moderate', 'Healthy', 'Unknown']),
                  'confidence_level': Schema.enumString(enumValues: ['Low', 'Medium', 'High']),
                  'brief_summary': Schema.string(),
                }
            )
        )
      }
  );

  //JSON format for output
  static final recommendationJsonSchema_PreviousMeals = Schema.object(
      properties:{
        'imbalanced_food_explanation': Schema.string(),
        'recommendations': Schema.array(
            items: Schema.object(
                properties: {
                  'meal_name': Schema.string(),
                  'description': Schema.string(),
                  'main_ingredients': Schema.array(
                    items: Schema.string(),
                  ),
                  'suitable_for': Schema.array(
                    items: Schema.enumString(enumValues: [
                      'Type-2 Diabetes',
                      'High Cholesterol',
                      'Weight Loss',
                      'Muscle Gain',
                      'General Health'
                    ]),
                  ),
                },
            ),
        ),
      },
  );

  //JSON format for output
  static final recommendationJsonSchema_NoPreviousMeals = Schema.object(
      properties:{
        'recommendations': Schema.array(
            items: Schema.object(
                properties: {
                  'meal_name': Schema.string(),
                  'description': Schema.string(),
                  'main_ingredients': Schema.array(
                    items: Schema.string(),
                  ),
                  'suitable_for': Schema.array(
                    items: Schema.enumString(enumValues: [
                      'Type-2 Diabetes',
                      'High Cholesterol',
                      'Weight Loss',
                      'Muscle Gain',
                      'General Health'
                    ]),
                  ),
                },
            ),
        ),
      },
  );

  //Initialise the Gemini Developer API backend
  final analysisModel = FirebaseAI.googleAI().generativeModel(
    // model: 'gemini-3.1-flash-lite-preview',
      model: 'gemini-2.5-flash-lite',
      generationConfig: GenerationConfig(
          responseMimeType: 'application/json', responseSchema: analysisJsonSchema));

  //Meal recommendation
  final recommendationModel_PreviousMeals = FirebaseAI.googleAI().generativeModel(
    // model: 'gemini-3.1-flash-lite-preview',
      model: 'gemini-2.5-flash-lite',
      generationConfig: GenerationConfig(
          responseMimeType: 'application/json', responseSchema: recommendationJsonSchema_PreviousMeals));

  //Meal recommendation
  final recommendationModel_NoPreviousMeals = FirebaseAI.googleAI().generativeModel(
    // model: 'gemini-3.1-flash-lite-preview',
      model: 'gemini-2.5-flash-lite',
      generationConfig: GenerationConfig(
          responseMimeType: 'application/json', responseSchema: recommendationJsonSchema_NoPreviousMeals));

}