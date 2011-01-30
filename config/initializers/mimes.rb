# register MIME type with MIME::Type gem
MIME::Types.add(MIME::Type.from_array("application/vnd.openxmlformats-officedocument.presentationml.presentation", %(pptx)))
MIME::Types.add(MIME::Type.from_array("application/vnd.oasis.opendocument.presentation", %(odp)))

