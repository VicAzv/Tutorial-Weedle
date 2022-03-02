version 1.0

workflow HelloHaplotypeCaller {
    input {
        File gatk
        File refFasta
        File refIndex
        File refDict
        String sampleName
        File inputBam
        File bamIndex
    }
    
    call HaplotypeCaller{
        input:
            gatk = gatk,
            refFasta = refFasta,
            refIndex = refIndex,
            refDict = refDict,
            sampleName = sampleName,
            inputBam = inputBam,
            bamIndex = bamIndex
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
        java -jar ~{GATK} \
            HaplotypeCaller \
            -R ~{refFasta} \
            -I ~{inputBAM} \
            -O ~{sampleName}.raw.indels.snps.vcf
        >>>
    }

    output {
        File rawVCF = "~{sampleName}.raw.indels.snps.vcf"
    }
}
