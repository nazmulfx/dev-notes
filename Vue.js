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

<span v-text="varible" ></span>
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






