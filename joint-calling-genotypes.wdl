version 1.0

workflow JointCallingGenotypes {
    input {
        File inputSamplesFile
        Array[Array[File]] inputSamples = read_tsv(inputSamplesFile)
        File gatk
        File refFasta
        File refIndex
        File refDict
    }

    scatter (sample in inputSamples) {
        call HaplotypeCallerERC {
            input:
                gatk = gatk, 
                refFasta = refFasta, 
                refIndex = refIndex, 
                refDict = refDict, 
                sampleName = sample[0],
                bamFile = sample[1], 
                bamIndex = sample[2]
        }
    }

    call CombineGVCFs {
        input:
            gatk = gatk, 
            refFasta = refFasta, 
            refIndex = refIndex, 
            refDict = refDict, 
            sampleName = "CEUtrio", 
            GVCFs = HaplotypeCallerERC.GVCF
        
    }

    call GenotypeGVCFs {
        input:
            gatk = gatk, 
            refFasta = refFasta, 
            refIndex = refIndex, 
            refDict = refDict, 
            sampleName = "CEUtrio", 
            combinedVCF = CombineGVCFs.combinedVCF
    }
}

task HaplotypeCallerERC {
    input {
        File gatk
        File refFasta
        File refIndex
        File refDict
        String sampleName
        File bamFile
        File bamIndex
    }

    command <<<
        java -jar ~{gatk} \
            HaplotypeCaller \
            -ERC GVCF \
            -R ~{refFasta} \
            -I ~{bamFile} \
            -O ~{sampleName}_rawLikelihoods.g.vcf
    >>>

    output {
        File GVCF = "~{sampleName}_rawLikelihoods.g.vcf"
    }
}

task CombineGVCFs {
    input {
        File gatk
        File refFasta
        File refIndex
        File refDict
        String sampleName
        Array[File] GVCFs
    }

    command <<<
        java -jar ~{gatk} \
            CombineGVCFs \
            -R ~{refFasta} \
            -V ~{sep=" -V " GVCFs} \
            -O ~{sampleName}_combineVariants.vcf
    >>>

    output {
        File combinedVCF = "${sampleName}_combineVariants.vcf"
    }
}

task GenotypeGVCFs {
    input {
        File gatk
        File refFasta
        File refIndex
        File refDict
        String sampleName
        File combinedVCF
    }

    command <<<
        java -jar ~{gatk} \
            GenotypeGVCFs \
            -R ~{refFasta} \
            -V ~{combinedVCF} \
            -O ~{sampleName}_genotypeVariants.vcf
    >>>

    output {
        File genotypedVCF = "${sampleName}_genotypeVariants.vcf"
    }
}