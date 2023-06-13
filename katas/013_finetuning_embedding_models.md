# 13th Kata: Fine-Tuning Embedding Models

In the previous kata, we explored the utilization of pre-trained embedding models to create a search index.
However, these models are trained on generic data and are not specifically tailored to the domain of our dataset.
In this kata, we will delve into the process of fine-tuning these models to make them more attuned to the specific domain.
This will enhance the accuracy of our vector search and improving the overall search experience for our users.

## Understanding Fine-Tuning

Pre-trained models excel at assessing semantic similarity in text values and images.
However, they lack optimization for specific use cases and datasets.
Consequently, they often struggle to capture the relevant notion of similarity within a particular domain.
For instance, when we used a pre-trained text model to evaluate the query "gaming mouse pad", it returned results for 
game pads, as both phrases contain tokens derived from the words "game" and "pad." 
Although one could argue for a semantic connection between these items, given their shared purpose in playing PC games,
recommending a game pad for a gaming mouse pad on an e-commerce website would not be ideal.
Additionally, pre-trained models frequently fail to comprehend the specific semantic understanding of domain-specific vocabulary.
As an example, when retrieving products for the query "microsoft office" using a pre-trained model, 
we received results for printers named "OfficeJet".
To address these issues, we can employ fine-tuning to adapt pre-trained models to the domain-specific terms and improve its grasp of the relevant notion of similarity.

## Using Jina's Finetuner to Create Tuned Embedding Models

Let's look at the steps which we need to perform to obtain a fine-tuned model with the [finetuner framework](https://github.com/jina-ai/finetuner):

1. Data Preparation: Extract the training data from your corpus of documents. This process varies depending on whether you are performing unsupervised or supervised training and whether you are using a text-to-text or text-to-image embedding model.

2. Configure and Submit the Fine-Tuning Job: Set up a fine-tuning job by configuring the desired model and its training parameters in the finetuners' fit function. After execution, the Finetuner will initiate a cloud computing job that performs the training using high-end GPU machines.

3. Monitor Your Job: Fine-tuning can be time-consuming. While the job is in progress, you can monitor it using either a Python script or the Finetuner's web interface. This allows you to retrieve logs, track evaluation metrics, and ensure everything is running smoothly.

4. Integrate the Model: Once the fine-tuning is complete, you can download the model, which can be integrated as a replacement into Chorus.

### Unsupervised Training of Text-to-Text Embedding Models

We begin by fine-tuning a pure text embedding model using an unsupervised approach.
In this approach, data annotation is not required.
Instead, the finetuner framework generates a dataset using a given corpus, such as our product database, along with a set of queries that can be extracted from a query log.
Since there is no query log for the demo database, we provide generated [queries](https://finetuner-ecommerce-experiment.s3.eu-central-1.amazonaws.com/generated-queries.jsonl) for download to run the demo code.
Those queries are generated with a [T5 language model trained on generating questions](https://huggingface.co/BeIR/query-gen-msmarco-t5-base-v1).

To establish relationships between queries and documents, we employ a pseudo labeling approach, similar to the one described in [this paper](https://arxiv.org/abs/2112.07577).
Specifically, for each query, we select two related documents using a pre-trained embedding model, as explained in the twelfth kata.
Subsequently, a cross-encoder model is employed to obtain a more precise estimation of relevance for both documents.
It is important to note that the cross-encoder model is more accurate but computationally more expensive, as it operates on the raw text inputs of the query and document, instead of relying on condensed vector representations.
Once the relevant data is generated, a fine-tuning job can be submitted to the finetuner cloud. 
The code for this process can be found in `finetuning/sbert_unsupervised.`

### Supervised Training of Text-to-Text Embedding Models

...

### Unsupervised Training of CLIP Models

For text-to-image retrieval, CLIP has emerged as one of the most popular retrieval models (learn more about CLIP [here]((https://openai.com/research/clip))).
Since there is no equivalent model like a cross encoder, which significantly outperforms the CLIP, we can still fine-tune CLIP for our specific domain by leveraging the existing connections between text and image attributes in our corpus.
To achieve this, we extract pairs of text attributes and product images from our dataset and utilize them as training data.
During fine-tuning the model learns to adjust semantically similar content as the product attributes to similar embeddings as their product images.
In contrast, queries which are rather related to the attributes of other products should be mapped to different embeddings.
The implementation of this approach, can be found in the `finetuning/clip_unsupervised` directory.

### Supervised Training of CLIP Models

...


## Integrating the Fine-Tuned Models

...
