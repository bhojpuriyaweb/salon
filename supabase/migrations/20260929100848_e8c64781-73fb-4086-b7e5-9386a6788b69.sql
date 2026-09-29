CREATE TABLE public.appointment_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name text NOT NULL CHECK (length(trim(full_name)) BETWEEN 2 AND 120),
  phone text NOT NULL CHECK (length(trim(phone)) BETWEEN 7 AND 25),
  email text NOT NULL CHECK (length(trim(email)) BETWEEN 5 AND 255),
  service text NOT NULL CHECK (service IN ('Haircut & Styling','Hair Color','Facial & Skincare','Manicure & Pedicure','Makeup','Spa & Wellness','Bridal Services','Other')),
  preferred_date date NOT NULL,
  preferred_time time NOT NULL,
  notes text NOT NULL DEFAULT '' CHECK (length(notes) <= 2000),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT INSERT ON public.appointment_requests TO anon, authenticated;
GRANT ALL ON public.appointment_requests TO service_role;
ALTER TABLE public.appointment_requests ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Visitors can request appointments" ON public.appointment_requests FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE OR REPLACE FUNCTION public.touch_appointment_updated_at() RETURNS trigger LANGUAGE plpgsql SET search_path = public AS $$ BEGIN NEW.updated_at = now(); RETURN NEW; END; $$;
CREATE TRIGGER appointment_updated_at BEFORE UPDATE ON public.appointment_requests FOR EACH ROW EXECUTE FUNCTION public.touch_appointment_updated_at();