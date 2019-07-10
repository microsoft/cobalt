ARG base_image

FROM $base_image

ARG build_directory
RUN echo "INFO: copying $build_directory"
# Copy the recently modified terraform templates
ADD $build_directory *.go ./
RUN find ./ -type f -iname "*.sh" -exec chmod +x {} \;

RUN echo "INFO: copying test-harness"
ADD test-harness/ ./test-harness

# Run a fresh clean/format/test run
CMD ["go", "run", "magefile.go"]