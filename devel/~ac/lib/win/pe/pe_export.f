 0
 4 -- ED.ExportFlags   \ Reserved, must be 0.
 4 -- ED.TimeDateStamp \ The time and date that the export data was created.
 2 -- ED.MajorVersion  \ The major version number. The major and minor version numbers can be set by the user.
 2 -- ED.MinorVersion  \ The minor version number.
 4 -- ED.NameRVA       \ The address of the ASCII string that contains the name of the DLL. This address is relative to the image base.
 4 -- ED.OrdinalBase   \ The starting ordinal number for exports in this image. This field specifies the starting ordinal number for the export address table. It is usually set to 1.
 4 -- ED.AddressTableEntries   \ The number of entries in the export address table.
 4 -- ED.NumberOfNamePointers  \ The number of entries in the name pointer table. This is also the number of entries in the ordinal table.
 4 -- ED.ExportAddressTableRVA \ The address of the export address table, relative to the image base.
 4 -- ED.NamePointerRVA  \ The address of the export name pointer table, relative to the image base. The table size is given by the Number of Name Pointers field.
 4 -- ED.OrdinalTableRVA \ The address of the ordinal table, relative to the image base.
CONSTANT /ExportDirectoryTable
