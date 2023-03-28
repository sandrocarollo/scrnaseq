process SAMPLESHEET_CHECK {
    tag "$samplesheet"
    label 'process_low'

    conda "conda-forge::python=3.8.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.8.3' :
        'quay.io/biocontainers/python:3.8.3' }"

    input:
    path samplesheet

    output:
    path '*.csv'       , emit: csv
    path "versions.yml", emit: versions
    path '*.fasq.gz'   , emit: renamed_fastq, optional: true
    
    when:
    task.ext.when == null || task.ext.when

    script: // This script is bundled with the pipeline, in nf-core/scrnaseq/bin/
    """
    check_samplesheet.py \\
        $samplesheet \\
        samplesheet.valid.csv
    if [ "${params.aligner}"=="cellranger" ]
    then
        samplesheet_cellranger_conform.py \\
        samplesheet.valid.csv \\
        samplesheet_cellranger.csv
    fi
    }
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}
