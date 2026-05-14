import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { 
      credit_score, age, tenure, balance, num_products, 
      has_card, is_active, salary, geography, gender 
    } = await req.json()

    // Model Parameters (Exported from our Python training)
    // In a real production environment, you could fetch these from Supabase Vault or a DB table
    const params = {
      coefficients: [
        -0.0006, 0.0725, -0.0154, 0.000002, -0.0512, -0.0102, -1.0543, 0.000001, 0.7542, 0.0521, -0.2541
      ],
      intercept: -3.5241,
      mean: [650.5, 38.9, 5.0, 76485.8, 1.53, 0.70, 0.51, 100090.2, 0.25, 0.24, 0.54],
      scale: [96.6, 10.4, 2.8, 62397.4, 0.58, 0.45, 0.49, 57510.4, 0.43, 0.43, 0.49]
    }

    // 1. Prepare Features
    const features = [
      credit_score, age, tenure, balance, num_products,
      has_card ? 1 : 0, is_active ? 1 : 0, salary,
      geography === 'Germany' ? 1 : 0,
      geography === 'Spain' ? 1 : 0,
      gender === 'Male' ? 1 : 0
    ]

    // 2. Scale Features
    const scaledFeatures = features.map((v, i) => (v - params.mean[i]) / params.scale[i])

    // 3. Logistic Regression Calculation
    let z = params.intercept
    for (let i = 0; i < scaledFeatures.length; i++) {
      z += scaledFeatures[i] * params.coefficients[i]
    }

    // 4. Sigmoid Function
    const probability = 1 / (1 + Math.exp(-z))

    return new Response(
      JSON.stringify({ probability, model: 'Neural-Logistic-Edge' }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
