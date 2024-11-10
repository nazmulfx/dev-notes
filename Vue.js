##################################################
##################  Install ######################
##################################################

npm create vue@latest

cd <your-project-name>
npm install
npm run dev


##################################################
############  Binding Text : v-text ##############
##################################################

{{ variable }}
    - bind text for a portion in a line

<h1 v-text="varible" ></h1>
    - bind text for full line

<template>
    <h1>{{ greet }} {{ name }}</h1>
    <h1 v-text="full_line"></h1>
</template>
<script>
    export default {
        name: "App", 
        data() {
            return {
                greet: "Hello,",
                name: "Nazmul",
                full_line: 'this is a full line of text',
            }
        }
    }
</script>


##################################################
############  Binding HTML : v-html ##############
##################################################

<p v-html="html"></p>
    - render html tag in inner side

<template>
    <p v-html="html"></p>
</template>
<script>
    export default {
        name: "App", 
        data() {
            return {
                html: '<b>Code Evolution</b>',
            }
        }
    }
</script>



########################################################
#####  Binding Attribute - id class style : v-bind #####
########################################################
Note: shorthand ":" refers to "v-bind:"

<template>
    <!-- Adding Attribute -->
    <h2 v-bind:id="red">Heading</h2>
    <button v-bind:disabled="isDisabled">Is Disabled Button</button>
    <h2 class="underline">Underlilne Text</h2>

    <!-- Adding Class using ternary operator -->
    <h2 v-bind:class="isComplete ? success : danger">Status</h2>

    <!-- Binding Class : Array Approch -->
    <h2 v-bind:class="['success', 'underline']">Binding Class : Array Approch</h2>
    <h2 v-bind:class="[inStock && 'success', isComplete ? 'underline' : 'sold-out']">Binding Class : Array Approch</h2>

    <!-- Binding Class : Object Approch -->
    <h2 v-bind:class="{'success': inStock, 'underline': isComplete, 'sold-out': !isComplete}">Binding Class : Object Approch</h2>

    <!-- Binding Style : key-value -->
    <h2 v-bind:style="{
        color: HighLightColor,
        'font-size': headerSize + 'px',
        marginTop: '10px',
    }">Inline Style : key-value pair</h2>
    <h2 v-bind:style="styleObject">Object Style : key-value pair</h2>

    <!-- v-bind shorthand -->
    <h2 :id="red">shorthand ":id" => "v-bind:id"</h2>
</template>
<script>
    export default {
        name: "App",
        data() {
            return {
                red: 'red',
                isDisabled: true,

                danger: 'danger',
                success: 'success',
                isComplete: false,

                inStock: true,

                HighLightColor: 'orange',
                headerSize: 50,

                styleObject: {
                    color: 'orange',
                    'font-size': '50px',
                    marginTop: '10px',
                }
            }
        }
    }
</script>
<style>
    #red {
        color: red;
    }
    .underline {
        text-decoration: underline;
    }
    .danger {
        background-color: rgba(255, 138, 138, 0.432);
    }
    .success {
        background-color: rgba(99, 255, 99, 0.432);
    }
    .sold-out {
        color: red;
    }
</style>



















        
