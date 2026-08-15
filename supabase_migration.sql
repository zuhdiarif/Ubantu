CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name text NOT NULL DEFAULT '',
  email text NOT NULL DEFAULT '',
  phone_number text NOT NULL DEFAULT '',
  nim text DEFAULT '',
  ktm_photo_url text,
  verification_status text NOT NULL DEFAULT 'unverified',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

GRANT ALL ON public.profiles TO anon, authenticated;

CREATE TABLE IF NOT EXISTS public.tasks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
  title text NOT NULL,
  category text NOT NULL DEFAULT 'bersihKos',
  location text NOT NULL DEFAULT '',
  date text NOT NULL DEFAULT '',
  time text NOT NULL DEFAULT '',
  requester_name text NOT NULL DEFAULT '',
  rating double precision NOT NULL DEFAULT 5.0,
  rating_count int NOT NULL DEFAULT 0,
  status text NOT NULL DEFAULT 'pending',
  created_at timestamptz NOT NULL DEFAULT now()
);

GRANT ALL ON public.tasks TO anon, authenticated;

CREATE TABLE IF NOT EXISTS public.sos_reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
  issue_type text NOT NULL,
  status text NOT NULL DEFAULT 'received',
  created_at timestamptz NOT NULL DEFAULT now()
);

GRANT ALL ON public.sos_reports TO anon, authenticated;

CREATE TABLE IF NOT EXISTS public.notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
  title text NOT NULL,
  message text NOT NULL,
  is_read boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

GRANT ALL ON public.notifications TO anon, authenticated;

CREATE TABLE IF NOT EXISTS public.barter_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL DEFAULT '',
  type text NOT NULL DEFAULT 'makanan',
  icon_asset text DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now()
);

GRANT ALL ON public.barter_items TO anon, authenticated;

INSERT INTO public.tasks (title, category, location, date, time, requester_name, rating, rating_count, status)
VALUES
  ('Bersih Kos', 'bersihKos', 'Jl. Kaliurang Km 5, Malang', '15 Aug 2026', '10:00', 'Dinda Putri', 4.6, 18, 'pending'),
  ('Pindah Kos', 'pindahKos', 'Jl. Sumbersari No. 12, Malang', '16 Aug 2026', '14:00', 'Rizky Aditya', 4.8, 25, 'pending'),
  ('Antar Jemput', 'antarJemput', 'Jl. Veteran No. 8, Malang', '17 Aug 2026', '09:30', 'Anisa Rahma', 4.9, 32, 'pending')
ON CONFLICT DO NOTHING;

INSERT INTO public.barter_items (title, description, type, icon_asset)
VALUES
  ('Makanan', 'Tukar jasa dengan makanan', 'makanan', 'fastfood_rounded'),
  ('Barang', 'Tukar jasa dengan barang', 'barang', 'card_giftcard_rounded')
ON CONFLICT DO NOTHING;
