import 'package:firebase_ai/firebase_ai.dart';

class GeminiController{


  //JSON format for output
  static final jsonSchema = Schema.object(
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

  //Initialise the Gemini Developer API backend
  final model = FirebaseAI.googleAI().generativeModel(
    // model: 'gemini-3.1-flash-lite-preview',
      model: 'gemini-2.5-flash-lite',
      generationConfig: GenerationConfig(
          responseMimeType: 'application/json', responseSchema: jsonSchema));

  //Meal recommendation

}