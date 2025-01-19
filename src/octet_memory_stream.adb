package body Octet_Memory_Stream is

   function To_Stream (Of_Array : Octet_Array) return Stream_Access is
   begin
      return
        new Memory_Stream'
          (Root_Stream_Type
           with
             Wrapped_Array => new Octet_Array'(Of_Array),
             Position      => Of_Array'First);
   end To_Stream;

   overriding
   procedure Read
     (Stream : in out Memory_Stream;
      Item   : out Stream_Element_Array;
      Last   : out Stream_Element_Offset)
   is
   begin
      for Index in Item'First .. Item'Last loop
         Item (Index) :=
           Stream_Element (Stream.Wrapped_Array.all (Stream.Position));
         Stream.Position := @ + 1;
      end loop;
      Last := Item'Last;
   exception
      when Constraint_Error =>
         raise Out_Of_Bounds_Error
            with "Reading beyond stream limit; octet array size is" &
            Stream.Wrapped_Array.all'Length'Image & ", current position:" &
            Stream.Position'Image & ", item buffer size:" & Item'Length'Image;
   end Read;

   overriding
   procedure Write (Stream : in out Memory_Stream; Item : Stream_Element_Array)
   is
   begin
      raise Program_Error with "Writing unsupported";
   end Write;

end Octet_Memory_Stream;
