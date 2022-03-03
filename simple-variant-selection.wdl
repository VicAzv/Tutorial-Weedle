version 1.0

workflow SimpleVariantSelectionTask {
    input {
        File gatk
        File refFasta
        File refIndex
        File refDict
        String sampleName
        File inputBam
        File bamIndex
        File testando
    }

    call HaplotypeCaller {
        input:
            gatk = gatk,
            refFasta = refFasta,
            refIndex = refIndex,
            refDict = refDict,
            sampleName = sampleName,
            inputBam = inputBam,
            bamIndex = bamIndex
    }

    call SimpleVariantSelection as selectSNPs { 
        input:
            gatk = gatk,
            refFasta = refFasta,
            refIndex = refIndex,
            refDict = refDict,
            sampleName = sampleName,
            type = "SNP", 
                rawVcf = testando
    }
    
    call SimpleVariantSelection as selectIndels { 
        input:
            gatk = gatk,
            refFasta = refFasta,
            refIndex = refIndex,
            refDict = refDict,
            sampleName = sampleName,
            type = "INDEL", 
                rawVcf = testando 
    }
}

task HaplotypeCaller {
    input {
        File gatk
        File refFasta
        File refIndex
        File refDict
        String sampleName
        File inputBam
        File bamIndex
    }

    command <<<
        java -jar ~{gatk} \
            HaplotypeCaller \
            -R ~{refFasta} \
            -I ~{inputBam} \
            -O ~{sampleName}.raw.indels.snps.vcf
    >>>

    output {
        File rawVcf = "~{sampleName}.raw.indels.snps.vcf"
    }
}

task SimpleVariantSelection {
    input {
        File gatk
        File refFasta
        File refIndex
        File refDict
        String sampleName
        String type
        File rawVcf
    }

    command <<<
        java -jar ~{gatk} \
            SelectVariants \
            -R ~{refFasta} \
            -V ~{rawVcf} \
            -select-type ~{type} \
            -O ~{sampleName}_raw.~{type}.vcf
    >>>

    output {
        File rawSubset = "~{sampleName}_raw.~{type}.vcf"
    }
}
