-- Create storage bucket for chat media
INSERT INTO storage.buckets (id, name, public)
VALUES ('chat-media', 'chat-media', true);

-- Create policy to allow authenticated users to upload files
CREATE POLICY "Allow authenticated users to upload chat media" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'chat-media' AND 
  auth.role() = 'authenticated'
);

-- Create policy to allow public access to view files
CREATE POLICY "Allow public access to chat media" ON storage.objects
FOR SELECT USING (bucket_id = 'chat-media');

-- Create policy to allow users to delete their own files
CREATE POLICY "Allow users to delete their own chat media" ON storage.objects
FOR DELETE USING (
  bucket_id = 'chat-media' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);