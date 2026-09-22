-- ==============================================================================
-- PUNEEXPLORER — DATABASE SEED DATA (DESTINATIONS, TOURS, WALKS, COUPONS, FAQS)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. CATEGORIES & TAGS SEED
-- ------------------------------------------------------------------------------
INSERT INTO public.categories (id, name, description, icon_name, display_order) VALUES
  ('historical', 'Historical & Forts', 'Ancient forts, wadas, and historical palaces of Maratha heritage', 'fort', 1),
  ('religious', 'Temples & Spiritual', 'Sacred temples, shrines, and darshan pilgrimage sites', 'temple', 2),
  ('nature', 'Nature & Viewpoints', 'Scenic hills, botanical gardens, lakes, and trekking trails', 'nature', 3),
  ('museum', 'Museums & Culture', 'Renowned art, artifact, and historical collections', 'museum', 4),
  ('food', 'Culinary & Culture', 'Famous food hubs, Puneri misal, and heritage sweet shops', 'restaurant', 5)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description;

INSERT INTO public.tags (id, label) VALUES
  ('heritage', 'Heritage'),
  ('trek', 'Sahyadri Trek'),
  ('spiritual', 'Spiritual'),
  ('scenic', 'Scenic Viewpoint'),
  ('family', 'Family Friendly'),
  ('budget', 'Budget Friendly')
ON CONFLICT (id) DO NOTHING;

-- ------------------------------------------------------------------------------
-- 2. DESTINATIONS SEED
-- ------------------------------------------------------------------------------
INSERT INTO public.destinations (
  id, slug, name, marathi_name, category_id, tag, short_description, full_description,
  hero_image, rating, review_count, entry_fee, best_time_to_visit, timings, ideal_duration,
  latitude, longitude, address, how_to_reach, is_featured, is_trending, is_active
) VALUES
  (
    'shaniwar-wada',
    'shaniwar-wada',
    'Shaniwar Wada',
    'शनिवार वाडा',
    'historical',
    'heritage',
    'Historical 18th-century fortification of the Peshwa rulers in Pune.',
    'Built in 1732 by Peshwa Baji Rao I, Shaniwar Wada served as the seat of the Peshwa rulers of the Maratha Empire until 1818. The fortress features massive spiked teakwood gates (Delhi Darwaza), intricate fountain gardens including the Hazari Karanje, and foundational stone plinths of the original seven-storey palace.',
    'https://images.unsplash.com/photo-1590050752117-238cb0fb12b1?w=1200&q=80',
    4.6, 1280, 25.0,
    'October to March',
    '8:00 AM - 6:30 PM (Light & Sound: 7:00 PM)',
    '2 hours',
    18.5196, 73.8553,
    'Shaniwar Peth, Pune, Maharashtra 411030',
    'Easily accessible via PMPML bus routes to Shaniwar Wada depot or Pune Metro Civil Court Station.',
    true, true, true
  ),
  (
    'aga-khan-palace',
    'aga-khan-palace',
    'Aga Khan Palace',
    'आगाखान पॅलेस',
    'historical',
    'heritage',
    'Majestic palace and memorial where Mahatma Gandhi was interned during the Freedom Movement.',
    'Constructed in 1892 by Sultan Muhammad Shah Aga Khan III as an act of charity to help famine-struck villagers. In 1942, Mahatma Gandhi, Kasturba Gandhi, and Mahadev Desai were imprisoned here during the Quit India Movement. The Italian arches and sprawling lawns house Kasturba Gandhi’s samadhi memorial.',
    'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=1200&q=80',
    4.7, 940, 50.0,
    'October to February',
    '9:00 AM - 5:30 PM',
    '2-3 hours',
    18.5524, 73.9015,
    'Pune-Nagar Road, Kalyani Nagar, Pune, Maharashtra 411006',
    'Located along Ahmednagar Highway, near Kalyani Nagar Metro Station. Direct auto-rickshaws available from Pune Junction.',
    true, true, true
  ),
  (
    'sinhagad-fort',
    'sinhagad-fort',
    'Sinhagad Fort',
    'सिंहगड किल्ला',
    'historical',
    'trek',
    'Legendary hill fortress atop the Sahyadri mountains with sweeping vistas and military history.',
    'Perched at 1,312 meters above sea level, Sinhagad is immortalized by Tanaji Malusare’s valiant 1670 battle. It commands 360-degree views of Khadakwasla Dam and the Western Ghats. Famous for rural Maharashtrian delicacy stalls serving steaming hot Kanda Bhaji, Pithla Bhakri, and chilled matka dahi.',
    'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=1200&q=80',
    4.8, 3420, 20.0,
    'June to February (Monsoon & Winter)',
    '6:00 AM - 6:00 PM',
    'Half day (4-5 hours)',
    18.3663, 73.7558,
    'Sinhagad Ghat Road, Thoptewadi, Maharashtra 411025',
    '30 km from Pune center. Direct PMPML buses ply from Swargate to Sinhagad Paytha (foothills). Shared jeeps drive to top gate.',
    true, true, true
  ),
  (
    'dagdusheth-ganpati',
    'dagdusheth-ganpati',
    'Shreemant Dagdusheth Halwai Ganpati Temple',
    'श्रीमंत दगडूशेठ हलवाई गणपती',
    'religious',
    'spiritual',
    'One of the most revered and visited Ganesh temples in Maharashtra.',
    'Founded in 1893 by sweet merchant Dagdusheth Gadve and his wife Lakshmibai after losing their son to the plague, this temple is the beating heart of Pune’s Ganeshotsav. The gold-adorned Ganpati idol is admired by millions of devotees and tourists worldwide.',
    'https://images.unsplash.com/photo-1567157577867-05ccb1388e66?w=1200&q=80',
    4.9, 5100, 0.0,
    'Year-round (Special during Ganeshotsav)',
    '6:00 AM - 10:30 PM',
    '1 hour',
    18.5165, 73.8560,
    'Ganpati Bhavan, 250, Budhwar Peth, Pune 411002',
    'Located in central Budhwar Peth, 5 minutes walk from Shaniwar Wada and Mandai Metro Station.',
    true, true, true
  ),
  (
    'pataleshwar-cave',
    'pataleshwar-cave',
    'Pataleshwar Cave Temple',
    'पाताळेश्वर गुहा मंदिर',
    'historical',
    'heritage',
    'Monolithic 8th-century rock-cut Shiva cave temple carved from basalt rock.',
    'Carved during the Rashtrakuta dynasty in the 8th century CE, this underground basalt cave temple honors Lord Shiva with a massive circular Nandi mandapa on stone pillars. Shaded by grand banyan trees on bustling JM Road.',
    'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=1200&q=80',
    4.5, 870, 0.0,
    'October to March',
    '8:30 AM - 5:30 PM',
    '1 hour',
    18.5283, 73.8504,
    'Jangali Maharaj Road, Shivajinagar, Pune 411005',
    'Walking distance from Shivajinagar Railway Station and PMC Metro Station.',
    false, false, true
  ),
  (
    'parvati-hill',
    'parvati-hill',
    'Parvati Hill & Peshwa Museum',
    'पार्वती टेकडी',
    'historical',
    'scenic',
    'Scenic hilltop with 103 stone steps offering panoramic city views and historic Peshwa temples.',
    'Standing 640 meters above sea level, Parvati Hill features a cluster of five 18th-century Peshwa-era temples dedicated to Devdeveshwar, Kartikeya, Vishnu, and Vitthal. The hill features the Peshwa Museum housing original Maratha artifacts, coins, and portraits.',
    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=1200&q=80',
    4.6, 1150, 0.0,
    'Early morning & late evening year-round',
    '5:00 AM - 8:00 PM',
    '2 hours',
    18.4975, 73.8475,
    'Parvati Paytha, Pune 411009',
    'Near Swargate bus terminus. Accessible by auto or city bus to Parvati Paytha.',
    false, true, true
  )
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  marathi_name = EXCLUDED.marathi_name,
  short_description = EXCLUDED.short_description,
  full_description = EXCLUDED.full_description,
  hero_image = EXCLUDED.hero_image,
  entry_fee = EXCLUDED.entry_fee,
  best_time_to_visit = EXCLUDED.best_time_to_visit,
  timings = EXCLUDED.timings,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  address = EXCLUDED.address;

-- Destination Highlights
INSERT INTO public.destination_highlights (destination_id, highlight, display_order) VALUES
  ('shaniwar-wada', 'Delhi Darwaza with anti-elephant spikes', 1),
  ('shaniwar-wada', 'Hazari Karanje (Thousand Jet Fountain)', 2),
  ('shaniwar-wada', 'Evening Light & Sound Show in Marathi and English', 3),
  ('sinhagad-fort', 'Kalyan Darwaza and Pune Darwaza fortifications', 1),
  ('sinhagad-fort', 'Authentic Pithla Bhakri, Thecha & Matka Dahi stalls', 2),
  ('sinhagad-fort', 'Tanaji Malusare Samadhi and memorial memorial', 3),
  ('aga-khan-palace', 'Kasturba Gandhi and Mahadev Desai Samadhis', 1),
  ('aga-khan-palace', 'Italian architectural arches and 19-acre lawns', 2),
  ('aga-khan-palace', 'Gandhi National Memorial museum galleries', 3);

-- Destination Food Spots
INSERT INTO public.destination_food_spots (destination_id, name, speciality, distance_meters, price_for_two, display_order) VALUES
  ('shaniwar-wada', 'Bedekar Tea Stall', 'Puneri Misal & Chai', 400, 180, 1),
  ('shaniwar-wada', 'Sujata Mastani', 'Mango and Kesar Mastani Ice Cream Milkshake', 300, 200, 2),
  ('sinhagad-fort', 'Tanaji Chulhavarachi Bhakri', 'Pithla Bhakri with Green Mirchi Thecha', 50, 250, 1),
  ('sinhagad-fort', 'Ghavan & Kanda Bhaji Shack', 'Crispy Kanda Bhaji & Chai', 80, 150, 2),
  ('dagdusheth-ganpati', 'Kaka Halwai Sweet Centre', 'Kaju Katli & Ukadiche Modak', 150, 220, 1),
  ('dagdusheth-ganpati', 'Chitale Bandhu Mithaiwale', 'Famous Puneri Bakarwadi & Amba Barfi', 350, 250, 2);

-- ------------------------------------------------------------------------------
-- 3. TOUR PACKAGES SEED
-- ------------------------------------------------------------------------------
INSERT INTO public.tours (
  id, title, subtitle, tour_type, duration_days, duration_hours, price_per_person,
  discounted_price, hero_image, overview, difficulty, max_group_size, rating, review_count,
  is_active, is_featured, inclusions, exclusions
) VALUES
  (
    'pune-darshan-full-day',
    'Pune Darshan Guided AC Coach Tour',
    'Cover all top 10 iconic Pune landmarks in a single comfortable day',
    'darshan',
    1, 9, 650.0, 500.0,
    'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=1200&q=80',
    'The quintessential Pune city tour. Experience Shaniwar Wada, Aga Khan Palace, Dagdusheth Halwai Ganpati, Pataleshwar Caves, Kelkar Museum, and Saras Baug with a certified Marathi & English speaking tour guide in an electric AC luxury coach.',
    'Easy', 35, 4.9, 412,
    true, true,
    '["AC Electric Coach Transportation", "Certified Multilingual Guide", "All Monument Entry Tickets", "Complimentary Water Bottle"]'::jsonb,
    '["Lunch and Snacks", "Personal Souvenirs", "Camera Fees at Museums"]'::jsonb
  ),
  (
    'sinhagad-sunrise-trek',
    'Sinhagad Fort Sunrise Trek & Rural Breakfast',
    'Breathtaking sunrise ridge climb followed by authentic Chulhavarachi Pithla Bhakri',
    'trek',
    1, 6, 899.0, 749.0,
    'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=1200&q=80',
    'Climb the historic ridge route from Donje village in the pre-dawn cool. Reach Pune Darwaza just as the first sun rays light up the Sahyadri mountains. Tour Tanaji Malusare’s monument and enjoy a piping hot village breakfast.',
    'Moderate', 20, 4.8, 184,
    true, true,
    '["Round-trip AC Transport from Swargate", "Experienced Trek Leader", "Authentic Pithla Bhakri Breakfast & Chai", "First Aid Support"]'::jsonb,
    '["Personal trekking gear", "Extra beverages"]'::jsonb
  ),
  (
    'rajgad-monsoon-trek',
    'Rajgad Fort Citadel & Padmavati Machi Trek',
    'Conquer the King of Forts — capital of Chhatrapati Shivaji Maharaj for over 25 years',
    'trek',
    1, 10, 1299.0, 1099.0,
    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=1200&q=80',
    'A majestic high-altitude trek visiting Chor Darwaza, Padmavati Temple, Suvela Machi, and the needle-eye Nedhe rock formation. Includes fort history briefing by expert Sahyadri mountaineers.',
    'Difficult', 25, 4.9, 96,
    true, false,
    '["Private Tempo Traveler Transport", "Certified Mountaineering Guides", "Full Rural Breakfast & Lunch", "Safety Equipment"]'::jsonb,
    '["Dinner", "Personal medical kit"]'::jsonb
  )
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  subtitle = EXCLUDED.subtitle,
  price_per_person = EXCLUDED.price_per_person,
  discounted_price = EXCLUDED.discounted_price,
  overview = EXCLUDED.overview,
  inclusions = EXCLUDED.inclusions,
  exclusions = EXCLUDED.exclusions;

-- Tour Boarding Points
INSERT INTO public.tour_boarding_points (tour_id, name, landmark, departure_time, display_order) VALUES
  ('pune-darshan-full-day', 'Swargate Bus Stand', 'Opposite Hotel Panchami', '07:30 AM', 1),
  ('pune-darshan-full-day', 'Pune Station', 'Near Inox Multiplex Gate', '08:00 AM', 2),
  ('pune-darshan-full-day', 'Shivajinagar', 'Outside Shivajinagar Metro Station', '08:20 AM', 3),
  ('sinhagad-sunrise-trek', 'Swargate', 'Near Mitra Mandal Chowk', '05:00 AM', 1),
  ('sinhagad-sunrise-trek', 'Kothrud Stand', 'Opposite Chandani Chowk Flyover', '05:25 AM', 2);

-- ------------------------------------------------------------------------------
-- 4. PUNE DARSHAN CIRCUITS SEED
-- ------------------------------------------------------------------------------
INSERT INTO public.darshan_circuits (
  id, circuit_code, title, description, departure_time, return_time, bus_type, fare_per_seat, is_active
) VALUES
  (
    'circuit-central-heritage',
    'PDC-01',
    'Classic Pune Heritage & Temples Circuit',
    'Visits Shaniwar Wada, Dagdusheth Ganpati, Saras Baug, Raja Kelkar Museum, and Parvati Hill.',
    '07:30 AM', '05:30 PM', 'AC Electric Coach', 500.0, true
  ),
  (
    'circuit-spiritual-suburban',
    'PDC-02',
    'Spiritual & Suburban Icons Circuit',
    'Visits Chaturshringi Temple, ISKCON NVCC Pune, Katraj Jain Temple, and Dehu Alandi Pilgrim Path.',
    '08:00 AM', '06:30 PM', 'AC Electric Coach', 650.0, true
  )
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  fare_per_seat = EXCLUDED.fare_per_seat;

-- ------------------------------------------------------------------------------
-- 5. HERITAGE WALKS SEED
-- ------------------------------------------------------------------------------
INSERT INTO public.heritage_walks (
  id, title, tagline, description, hero_image, duration_minutes, distance_km, difficulty,
  start_point, end_point, ticket_price, is_active
) VALUES
  (
    'walk-old-pune-wadas',
    'Old Pune Peths & Wada Architecture Trail',
    'Step back into the 18th-century alleys and timber courtyards of the Peshwa capital',
    'Wander through Kasba Peth, Raviwar Peth, and Somwar Peth. Learn how Maratha courtyard houses were engineered with rainwater cisterns, carved teak woodwork, and secret escape tunnels.',
    'https://images.unsplash.com/photo-1590050752117-238cb0fb12b1?w=1200&q=80',
    150, 3.2, 'Easy',
    'Shaniwar Wada Delhi Gate',
    'Nana Wada Courtyard',
    299.0, true
  ),
  (
    'walk-camp-colonial-charm',
    'Pune Camp & Colonial Legacy Walk',
    'Victorian churches, Irani bakeries, and military cantonment history',
    'Explore St. Mary’s Church, the iconic West End Cinema, Kohinoor Restaurant for Bun Maska Chai, and the vintage architecture of MG Road.',
    'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=1200&q=80',
    120, 2.5, 'Easy',
    'St. Mary’s Church, Camp',
    'East Street Irani Bakery',
    349.0, true
  )
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  tagline = EXCLUDED.tagline,
  ticket_price = EXCLUDED.ticket_price;

-- ------------------------------------------------------------------------------
-- 6. COUPONS & PROMOTIONS SEED
-- ------------------------------------------------------------------------------
INSERT INTO public.coupons (
  id, code, title, description, discount_type, discount_value,
  min_booking_amount, max_discount_amount, valid_from, valid_until,
  usage_limit, times_used, is_active
) VALUES
  (
    'coup-darshan50',
    'DARSHAN50',
    'Pune Darshan Special ₹50 Off',
    'Flat ₹50 off per seat on all Pune Darshan bus circuits',
    'flat', 50.0, 450.0, 50.0,
    NOW() - INTERVAL '30 days', NOW() + INTERVAL '180 days',
    5000, 128, true
  ),
  (
    'coup-trek15',
    'TREK15',
    'Sahyadri Monsoon Trek 15% Off',
    '15% instant discount on all weekend Sahyadri fort treks',
    'percentage', 15.0, 700.0, 250.0,
    NOW() - INTERVAL '30 days', NOW() + INTERVAL '180 days',
    1000, 64, true
  ),
  (
    'coup-puneri99',
    'PUNERI99',
    'Heritage Walk Flat ₹99 Off',
    'Special promotion for guided walking tours in historic peths',
    'flat', 99.0, 250.0, 99.0,
    NOW() - INTERVAL '10 days', NOW() + INTERVAL '120 days',
    500, 31, true
  ),
  (
    'coup-pune2026',
    'PUNE2026',
    'Explore Pune 2026 Launch Special',
    '10% off across all tours and packages for registered members',
    'percentage', 10.0, 500.0, 300.0,
    NOW() - INTERVAL '5 days', NOW() + INTERVAL '365 days',
    10000, 214, true
  )
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  discount_value = EXCLUDED.discount_value,
  is_active = EXCLUDED.is_active;

-- ------------------------------------------------------------------------------
-- 7. FAQS SEED
-- ------------------------------------------------------------------------------
INSERT INTO public.faqs (id, question, answer, category, display_order, is_active) VALUES
  (
    'faq-darshan-timing',
    'What are the timings of the Pune Darshan bus tour?',
    'The bus departs sharp at 07:30 AM from Swargate and 08:00 AM from Pune Station. The tour concludes around 05:30 PM to 06:00 PM at Swargate.',
    'Tours & Darshan', 1, true
  ),
  (
    'faq-payment-methods',
    'Which payment modes are supported for booking confirmation?',
    'We support instant UPI QR Code payments (Google Pay, PhonePe, Paytm, BHIM, Cred) as well as direct UTR verification.',
    'Payments & Bookings', 2, true
  ),
  (
    'faq-cancellation-policy',
    'What is the cancellation and refund policy?',
    'Cancellations made 24 hours prior to travel date receive an 80% refund. Cancellations within 24 hours incur a 50% fee. Same day no-shows are non-refundable.',
    'Cancellations & Refunds', 3, true
  ),
  (
    'faq-monsoon-trekking',
    'Is Sinhagad or Rajgad fort trek safe during heavy monsoon?',
    'All guided treks are led by certified Sahyadri mountaineers equipped with safety ropes and first aid. If weather authorities issue a Red Alert, trips are rescheduled at no extra charge.',
    'Safety & Trekking', 4, true
  )
ON CONFLICT (id) DO UPDATE SET
  question = EXCLUDED.question,
  answer = EXCLUDED.answer;

-- ------------------------------------------------------------------------------
-- 8. APP SETTINGS SEED
-- ------------------------------------------------------------------------------
INSERT INTO public.app_settings (key, value, description, updated_by) VALUES
  (
    'general',
    '{"app_name": "PuneExplorer", "helpline": "1363", "support_email": "support@puneexplorer.in", "emergency_police": "112", "maintenance_mode": false}'::jsonb,
    'Core general application metadata',
    'system'
  ),
  (
    'payments',
    '{"merchant_upi_id": "puneexplorer@icici", "merchant_name": "PuneExplorer Tourism", "default_currency": "INR", "payment_timeout_minutes": 20, "auto_verify_threshold": 0}'::jsonb,
    'UPI and payment gateway settlement settings',
    'system'
  ),
  (
    'booking_rules',
    '{"same_day_cutoff_hours": 3, "cancellation_grace_hours": 24, "max_travelers_per_booking": 10}'::jsonb,
    'Booking business rules and constraints',
    'system'
  )
ON CONFLICT (key) DO UPDATE SET
  value = EXCLUDED.value;
