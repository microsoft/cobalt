ARG base_image

FROM $base_image

ARG build_directory
RUN echo "INFO: copying $build_directory"
# Copy the recently modified terraform templates
ADD $build_directory *.go ./

# TODO: when this is moved into the orion repo the following line can be deleted
ADD test-harness/ ./test-harness

# Run a fresh clean/format/test run
CMD ["go", "run", "magefile.go"]