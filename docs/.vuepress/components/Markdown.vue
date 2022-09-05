<script>
import { h } from "vue";
import markdownIt from "markdown-it";

export default {
    props: {
        text: {
            type: String,
            required: true
        }
    },

    render() {
        // Create markdown renderer engine.
        let renderer = new markdownIt({ html: true });

        // Render the component template.
        return h(
            "div",
            {
                // Add class for our own reference.
                class: "user-rendered-markdown",

                // Convert the text to markdown.
                innerHTML: renderer.render(this.text)
            }
        );
    }
}
</script>
